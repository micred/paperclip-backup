module Paperclip
  module Backup

    class Compressor

      def self.get_attachment(resource, attachment, backup_dir)
        FileUtils.mkdir_p backup_dir
        filename = "#{backup_dir}/#{resource.id}#{File.extname(resource.send("#{attachment}_file_name"))}"

        # Try 3 times to download
        3.times do
          begin
            s3_md5 = nil
            File.open(filename, 'wb') do |file|
              transfer = resource.send(attachment).s3_object(:original).read do |chunk|
                file.write(chunk)
              end
              s3_md5 = transfer[:etag].gsub('"', '')
            end

            # Check if file is downloaded correctly
            downloaded_md5 = Digest::MD5.hexdigest(File.read(filename))
            return filename  if s3_md5 == downloaded_md5
          rescue
          end
        end

        raise "Cannot download attachment #{attachment}(:original) of #{resource.class.name} with id: #{resource.id}."
      end


      def self.compress zipfile_name, source_dir
        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          Dir["#{source_dir}/*"].each do |filename|
            zipfile.add(File.basename(filename), filename)
          end
        end
      end


      def self.upload_to_glacier zipfile_name
        glacier = Fog::AWS::Glacier.new({
                                            aws_access_key_id: Paperclip::Backup.aws_access_key_id,
                                            aws_secret_access_key: Paperclip::Backup.aws_secret_access_key,
                                            region: Paperclip::Backup.glacier_region
                                        })
        vault = glacier.vaults.create id: Paperclip::Backup.glacier_vault
        job = vault.archives.create body: File.new(zipfile_name),
                                    description: "Archive #{zipfile_name}",
                                    multipart_chunk_size: 1024*1024
      end

      def self.retrieve
        # http://www.spacevatican.org/2012/9/4/using-glacier-with-fog/
      end
    end
  end
end