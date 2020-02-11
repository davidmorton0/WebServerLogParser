class LogReader
  include Constants

  WARNING_NAMES = {
    log: 'log',
    ip4: 'ip4 address',
    ip6: 'ip6 address',
    ip4_ip6: 'ip address',
    path: 'path'
  }

  attr_accessor :options, :read_log, :warnings, :logs_read, :logs_added, :files_read

  def initialize(options: {})
    @read_log = Hash.new { |h, k| h[k] = [] }
    @options = options
    @warnings = [];
    @logs_read = 0;
    @logs_added = 0;
    @files_read = [];
    if options[:file]
      load_log(file: options[:file])
    elsif options[:file_list]
      options[:file_list].each{ |file| load_log(file: file) }
    end
  end

  def load_log(file:)
    begin
      File.open(file,'r').each.with_index { |line, i|
        add_log(log: line, line_number: i + 1, file: file) }
      @files_read.push(file)
    rescue
      warnings.push({ type: :file, message: " - File not found: %s" % file })
    end
    self
  end

  def add_log(log:, line_number: 1, file:)
    @logs_read += 1

    log_valid = valid_log?(log: log)
    add_warning_if(type: :log, line_number: line_number, file: file,
                   add_if: !log_valid)
    return self if !log_valid

    path, ip_address = log.split(' ')
    ip_valid = valid_ip?(ip_address: ip_address)
    path_valid = valid_path?(path: path)

    add_warning_if(type: options[:ip_validation], line_number: line_number,
                   file: file, add_if: !ip_valid)
    add_warning_if(type: :path, line_number: line_number, file: file,
                   add_if: !path_valid)

    if (ip_valid && path_valid) || !options[:log_remove]
      @logs_added += 1
      read_log[path].push(ip_address)
    end
    self
  end

  def add_warning_if(type:, line_number:, file:, add_if:)
    if add_if
      warnings.push({ type: type,
                    message: log_warning_message(
                      name: WARNING_NAMES[type],
                      line_number: line_number,
                      file: file) })
    end
  end

  def log_warning_message(name:, line_number:, file:)
    " - Invalid %<name>s%<line_file>s" % { name: name,
      line_file: add_line_and_file_name(line_number, file) }
  end

  def add_line_and_file_name(line_number, file)
    add_file_name(file) + " - line %<line>d" % { line: line_number }
  end

  def add_file_name(file)
    " - File: %<file>s" % { file: file }
  end

  def valid_ip?(ip_address:)
    IpValidator.new(ip_address: ip_address,
                    validation: options[:ip_validation]).valid?
  end

  def valid_log?(log:)
    !!log.match(VALID_LOG)
  end

  def valid_path?(path:)
    PathValidator.new(path: path).valid?
  end

end
