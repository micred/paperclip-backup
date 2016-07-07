require 'paperclip/backup/version'
require 'paperclip/helpers/configuration'
require 'paperclip/backup/backup_attached_file'
require 'paperclip/backup/compressor'
require 'fog'


module Paperclip
  module Backup
    extend Configuration
    extend ActiveSupport::Concern

    # Whenever schedule
    define_setting :run_at

    # AWS credentials and Glacier configuration
    define_setting :aws_access_key_id
    define_setting :aws_secret_access_key
    define_setting :glacier_region
    define_setting :glacier_vault

    module ClassMethods
      def backup_attached_file(name, options = {})
        BackupAttachedFile.define_on(self, name, options)
      end
    end

    define_class_method :backup_all_models! do
      Rails.application.eager_load!
      ActiveRecord::Base.descendants.each do |model|
        model.methods.grep(/backup_paperclip_(.*)!/).each {|attachment| model.send attachment}
      end
      nil
    end
  end
end

# Is it right to include module here?!
ActiveRecord::Base.send(:include, Paperclip::Backup)
