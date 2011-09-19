require_dependency 'project'
#TODO: You must apply the redmine_helper patch first
module MarkupProjectPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            safe_attributes 'text_formatting' unless Redmine::VERSION::MAJOR == 1 && Redmine::VERSION::MINOR == 0 # Redmine 1.0.x
        end
    end

    module ClassMethods
    end

    module InstanceMethods
    end

end
