module ActiveRecord #:nodoc:
  class Base
    class << self
      def database_name
        set_database_name
      end

      def set_database_name(value = nil, &block)
        define_attr_method :database_name, value, &block
      end
      alias :database_name= :set_database_name

      def reset_table_name #:nodoc:
        base = base_class

        name =
          # STI subclasses always use their superclass' table.
          unless self == base
            base.table_name
          else
            # Nested classes are prefixed with singular parent table name.
            if parent < ActiveRecord::Base && !parent.abstract_class?
              contained = parent.table_name
              contained = contained.singularize if parent.pluralize_table_names
              contained << '_'
            end
            name = "#{table_name_prefix}#{contained}#{undecorated_table_name(base.name)}#{table_name_suffix}"
          end

        base.database_name.nil? ? db = '' : db = "#{base.database_name}."
        set_table_name("#{db}#{name}")
        "#{db}#{name}"
      end
    
    # Establishes a connection to the database that's used by all Active Record objects.
      def mysql_connection(config) # :nodoc:
        config = config.symbolize_keys
        host     = config[:host]
        port     = config[:port]
        socket   = config[:socket]
        username = config[:username] ? config[:username].to_s : 'root'
        password = config[:password].to_s
        database = config[:database]

        require_mysql
        mysql = Mysql.init
        mysql.ssl_set(config[:sslkey], config[:sslcert], config[:sslca], config[:sslcapath], config[:sslcipher]) if config[:sslkey]

        ConnectionAdapters::MysqlAdapter.new(mysql, logger, [host, username, password, database, port, socket], config)
      end
    end
  end
end
