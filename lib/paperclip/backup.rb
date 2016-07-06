require 'paperclip/backup/version'
require 'paperclip/helpers/configuration'
require 'paperclip/backup/backup_attached_file'


module Paperclip
  module Backup
    extend Configuration
    extend ActiveSupport::Concern

    # define_setting :access_token
    # define_setting :access_secret
    # define_setting :backup_models, []
    define_setting :run_at, []           # Whenever schedule


    module ClassMethods
      def backup_attached_file(name, options = {})
        BackupAttachedFile.define_on(self, name, options)
      end

      # def hello(options = {})
      #   puts 1
      #   # your code will go here
      # end
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