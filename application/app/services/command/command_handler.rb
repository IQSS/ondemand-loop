# frozen_string_literal: true

# CommandHandler is an interface-style module for all command server handlers.
#
# Classes that handle incoming commands from the CommandServer should include this
# module and implement the `#handle_command(request)` method.
#
# Example:
#
#   class ShutdownHandler
#     include CommandHandler
#
#     def handle_command(request)
#       # perform shutdown and return a response
#       { status: 'ok', message: 'Shutdown initiated' }
#     end
#   end
#
# By including this module, developers make it explicit that their class
# participates in the command handling contract. If `#handle_command` is not
# implemented, a NotImplementedError will be raised at runtime.
#
module Command::CommandHandler
  def handle_command(_request)
    raise NotImplementedError, "#{self.class} must implement #handle_command"
  end
end
