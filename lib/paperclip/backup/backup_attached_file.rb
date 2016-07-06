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
      def migrations_must_be_present
        Rails.logger.error "paperclip-backup: missing has_attached_file :#{@name} for model #{@klass}"
        Rails.logger.error "paperclip-backup: missing migrations for attachment :#{@name} of model #{@klass}"

        # @klass.respond_to?(:)
      end

      def define_class_getter
        migrations_must_be_present

        name = @name
        @klass.send :define_singleton_method, "backup_paperclip_#{@name}!" do

          # self è la classe
          puts "backup_paperclip_#{name}!"
        end

        @klass.extend(ClassMethods)
      end


      def add_active_record_callbacks
        # name = @name
        # @klass.send(:after_save) { send(name).send(:save) }
        # @klass.send(:before_destroy) { send(name).send(:queue_all_for_delete) }
        # if @klass.respond_to?(:after_commit)
        #   @klass.send(:after_commit, on: :destroy) do
        #     send(name).send(:flush_deletes)
        #   end
        # else
        #   @klass.send(:after_destroy) { send(name).send(:flush_deletes) }
        # end
        #
        # @klass.send(
        #     :define_paperclip_callbacks,
        # :post_process, :"#{@name}_post_process")
      end

      module ClassMethods
        # def backup_paperclip_attachments?
        #   true
        # end
      end

    end
  end
end