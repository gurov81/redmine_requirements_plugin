module WikiRequirementsPlugin
  # Patches Redmine's Issues dynamically. Adds two belongs_to relationships,
  # and makes some other changes required for the two new fields.
  module IssuePatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      
      # Wrap the methods we are extending
      #base.alias_method_chain :validate, :wrapping
      #base.alias_method_chain :move_to,  :wrapping

      # Exectue this code at the class level (not instance level)
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        belongs_to :requirement, :class_name => 'Version', :foreign_key => 'requirement_id'
      end #base.class_eval

    end #self.included
    
    module ClassMethods
    end
    
    module InstanceMethods
      
      # Wrapped validator - calls the original validator then does extra checks
      def validate_with_wrapping
        validate_without_wrapping
        
        
        #if found_in_version
        #  if !assignable_versions.include?(found_in_version)
        #    errors.add :found_in_version_id, :inclusion
        #  end
        #end
        #if release_notes_version
        #  if !assignable_versions.include?(release_notes_version)
        #    errors.add :release_notes_version_id, :inclusion
        #  end
        #end
      end #validate_with_wrapping

      # Wrapped move_to - calls the original mover, then ensures the versions are 
      # still valid.
      def move_to_with_wrapping (new_project, new_tracker = nil, options = {})
        result = move_to_without_wrapping(new_project, new_tracker, options)
        
        # Result will either be the moved issue (success), or false (failure)
        #if (result != false)
        #  unless new_project.shared_versions.include?(result.found_in_version)
        #    result.found_in_version = nil
        #  end
        #  unless new_project.shared_versions.include?(result.release_notes_version)
        #    result.release_notes_version = nil
        #  end
        #  result.save
        #end
        result
      end #move_to_with_wrapping

    end #InstanceMethods

  end #IssuePatch

end #RedmineVersionFields

#TODO
#-Extend the following methods:
#  -self.update_versions(conditions=nil)
#  -self.update_versions_from_sharing_change(version)
#  -self.update_versions_from_hierarchy_change(project)
#-Show strings not IDs in journal
