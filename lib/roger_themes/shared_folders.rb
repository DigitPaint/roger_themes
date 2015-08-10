module RogerThemes
  class SharedFolders
    attr_reader :folders

    def initialize(folders)
      # To allow shared_folders to passed in as array
      # in cases the mapping becomes 1:1 update shared_folders to Hash
      if folders.is_a? Array
        paths = folders.map { |v| [v, v] }
        @folders = Hash[paths]
      else
        @folders = folders
      end
    end

    # Takes an local theme path
    # and tries to resolve this to
    # shared path
    def local_to_shared_path(path)
      matched_shared = @folders.detect do |folder_to, folder_from|
        if path[/\A\/themes\/([^\/]+)\/#{folder_from}\//, 1]
          [folder_to, folder_from]
        end
      end

      if matched_shared
        path.sub(/\A\/themes\/([^\/]+)\/#{matched_shared[1]}/,
                 "/#{matched_shared[0]}")
      else
        false
      end
    end
  end
end
