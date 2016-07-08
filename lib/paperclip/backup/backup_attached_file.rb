module Paperclip
  module Backup

    class BackupAttachedFile

      def self.define_on(klass, name, options)
        new(klass, name, options).define
      end

      def initialize(klass, name, options)
        @klass = klass
        @name = name
        @options = options
      end

      def define
        define_class_getter
        add_active_record_callbacks
      end


      private
      def define_class_getter
        return unless migrations_present? and aws_configuration_present?

        name = @name
        @klass.send :define_singleton_method, "backup_paperclip_#{@name}!" do
          backup_at = Time.now

          # Look up modified resources
          resources = self.where('(image_file_name IS NOT NULL) AND (image_last_backup_at IS NULL OR (image_updated_at > image_last_backup_at))')
          return if resources.blank?  # Nothing to backup.

          # Download original files and backup
          backup_name = "#{backup_at.to_s(:number)}_#{self.name.underscore}_#{name}"
          backup_dir = "#{Rails.root}/tmp/paperclip_backup/#{backup_name}"
          backup_file = "#{backup_dir}.zip"

          resources.each do |resource|
            Compressor.get_attachment resource, name, backup_dir
          end

          Compressor.compress backup_file, backup_dir

          job = Compressor.upload_to_glacier backup_file

          # Backup done correctly, update Glacier references with "backup name" and "Glacier archive id".
          # Notice: update is not done via update_all() since it suffer concurrency problems (it updates all rows
          #         that matches the SQL query, that are not necessarily the same of local variable resources).
          resources.each do |resource|
            resource.update "#{name}_last_backup_at" => backup_at,
                            "#{name}_backup_archives" => resource["#{name}_backup_archives"] + ["#{backup_name}-#{job.id}"]
            # Workaround since << operator doesn't work with PG arrays in Rails 4.1
          end

          # Clean up
          FileUtils.rm_rf backup_dir
          FileUtils.rm backup_file

          return resources
        end

        @klass.extend(ClassMethods)
      end


      def add_active_record_callbacks
      end

      def migrations_present?
        Rails.logger.error "paperclip-backup: missing has_attached_file :#{@name} for model #{@klass}"
        Rails.logger.error "paperclip-backup: missing migrations for attachment :#{@name} of model #{@klass}"

        #TODO
        true
      end

      def aws_configuration_present?
        Rails.logger.error "paperclip-backup: missing AWS credentials and/or Glacier vault configuration"

        #TODO
        true
      end

      module ClassMethods
        # def backup_paperclip_attachments?
        #   true
        # end
      end

    end
  end
end
