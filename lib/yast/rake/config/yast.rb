module Yast
  module Rake
    module Config
      module Yast
        INSTALL_DIR = '/usr/share/YaST2/'
        CLIENTS_DIR = "#{INSTALL_DIR}/clients"
        MODULES_DIR = "#{INSTALL_DIR}/modules"
        DESKTOP_DIR = '/usr/share/applications/YaST2/'
        DOC_DIR     = '/usr/share/doc/packages/'
        AUTOYAST_RNC_DIR = "#{INSTALL_DIR}/schema/autoyast/rnc"

        def install_dir
          INSTALL_DIR
        end

        def desktop_dir
          DESKTOP_DIR
        end

        def doc_dir
          DOC_DIR
        end
      end
    end
  end
end
