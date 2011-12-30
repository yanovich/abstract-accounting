require "rspec/core/formatters/progress_formatter"

class CustomFormatter < RSpec::Core::Formatters::ProgressFormatter
  def dump_backtrace(example)
    format_backtrace(example.execution_result[:exception].backtrace, example).each do |backtrace_info|
      output.puts cyan("#{long_padding}#{backtrace_info}")
    end
  end
end

# vim:ts=2 sts=2 sw=2 et:
