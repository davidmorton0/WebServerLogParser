# frozen_string_literal: true

require 'optparse'

# Parses command line options
class OptionHandler
  include Constants

  attr_reader :options

  def initialize
    @options = DEFAULT_OPTIONS.clone
    @options[:file_list] = []

    begin
      OptionParser.new do |opts|
        opts.on('-v', '--verbose', 'Show extra information') do
          options[:verbose] = true unless options[:quiet]
        end

        opts.on('-q', '--quiet',
                'No display except important warnings.  Disables verbose') do
          options[:quiet] = true
          options[:verbose] = false
        end

        opts.on('-c', '--color', 'Enables colored display text') do
          options[:highlighting] = true
        end

        opts.on('-C', '--no_color',
                'Disables colored display text (default)') do
          options[:highlighting] = false
        end

        opts.on('-f', '--file [FILE]',
                'Log file to read. Default is webserver.log') do |file|
          if file
            options[:file_list].push(file)
          else
            unless ENV['APP_ENV'] == 'test'
              puts 'Missing input file name.  Exiting.'
            end
            exit 50
          end
        end

        opts.on('-m', "--multiple_files ['FILE_LIST']",
                'Read a list of log files in quotes') do |file_list|
          if file_list
            options[:file_list] += file_list.split(' ')
          else
            unless ENV['APP_ENV'] == 'test'
              puts 'Missing input file list.  Exiting.'
            end
            exit 50
          end
        end

        opts.on('-o', '--output_file [FILE]', 'Write output to file') do |file|
          options[:output_file] = file || 'log_info.txt'
        end

        opts.on('-t', '--timestamp', 'Add timestamp to output file') do
          options[:timestamp] = true
        end

        opts.on('-x', '--text', 'Sets file output format to text (default)') do
          options[:output_format] = :text
        end

        opts.on('-j', '--json', 'Sets file output format to json') do
          options[:output_format] = :json
        end

        opts.on('-h', '--help', 'Shows help') do
          puts opts if ENV['APP_ENV'] != 'test'
          exit 51
        end

        opts.on('-4', '--ip4_validation',
                'Validate ip addresses using ip4 format (default)') do
          options[:ip_validation] = :ip4
        end

        opts.on('-6', '--ip6_validation',
                'Validate ip addresses using ip6 format') do
          options[:ip_validation] = :ip6
        end

        opts.on('-i', '--ip4ip6_validation',
                'Validate ip addresses using either ip4 or ip6 format') do
          options[:ip_validation] = :ip4_ip6
        end

        opts.on('-I', '--no_ip_validation',
                'No validatation of ip addresses') do
          options[:ip_validation] = :none
        end

        opts.on('-r', '--remove_invalid',
                'Ignore log if invalid ip addresss or path') do
          options[:log_remove] = true
        end

        opts.on('-R', '--warn_invalid',
                'Warn but not ignore log if invalid ip address or path
                (default)') do
          options[:log_remove] = false
        end

        opts.on('-p', '--path_validation', 'Validate webpage path (default)') do
          options[:path_validation] = true
        end

        opts.on('-P', '--no_path_validation',
                'Does not validate webpage path') do
          options[:path_validation] = false
        end

        opts.on('-g', '--page_visits', 'Show page visits (default)') do
          options[:page_visits] = true
        end

        opts.on('-G', '--no_page_visits', 'Do not show page visits') do
          options[:page_visits] = false
        end

        opts.on('-u', '--unique_page_views',
                'Show unique page views (default)') do
          options[:unique_page_views] = true
        end

        opts.on('-U', '--no_unique_page_views',
                'Do not show unique page views') do
          options[:unique_page_views] = false
        end
      end.parse!
    rescue OptionParser::InvalidOption => e
      puts e if ENV['APP_ENV'] != 'test'
      exit
    end
  end
end
