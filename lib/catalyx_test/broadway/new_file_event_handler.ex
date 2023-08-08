defmodule CatalyxTest.Broadway.NewFileEventHandler do
  use Broadway

  alias Broadway.Message
  alias CatalyxTest.CsvProcessor

  defp queue_url,
       do:
         "#{Application.get_env(:ex_aws, :sqs)[:base_queue_url]}#{Application.get_env(:ex_aws, :sqs)[:new_files_queue]}"

  defp producer_module, do: Application.get_env(:catalyx_test, :broadway)[:producer_module]

  def start_link(_opts) do
    {module, opts} = producer_module()
    options = opts ++ [queue_url: queue_url()]

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {module, options}
      ],
      processors: [
        default: []
      ]
    )
  end

  @impl true
  def handle_message(_processor, %Broadway.Message{data: data} = message, _context) do
    decoded_data =
      case Jason.decode!(data) do
        %{"Message" => message} -> Jason.decode!(message)
        message -> message
      end

    case decoded_data do
      %{"Records" => records} ->
        Enum.each(records, fn
          %{
            "eventName" => event_name,
            "eventSource" => "aws:s3",
            "s3" => %{
              "object" => %{
                "key" => object_key
              }
            }
          }
          when event_name in ["ObjectCreated:Put", "ObjectCreated:Post"] ->
            CsvProcessor.schedule_file(object_key)
          _ ->
            :ok
        end)
      _ ->
        :ok
    end

    Message.update_data(message, fn _data -> decoded_data end)
  end
end