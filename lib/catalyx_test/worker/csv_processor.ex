defmodule CatalyxTest.CsvProcessor do
  use GenServer

  @doc """
  Simple list as state
  """
  @impl true
  def init(_) do
    schedule_file_check()

    {:ok, {[], false}}
  end

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: CsvProcessor)
  end

  def handle_call(:lookup, _, state), do: {:reply, state, state}

  def lookup() do
    GenServer.call(CsvProcessor, :lookup)
  end

  @impl true
  def handle_cast({:add, file}, {files, processing}) do
    {:noreply, {[file | files], processing}}
  end
  def handle_cast(:continue, {files, processing}) do
    {:noreply, {files, processing}}
  end

  def schedule_file(file) do
    GenServer.cast(CsvProcessor, {:add, file})
  end

  defp continue_process() do
    GenServer.cast(CsvProcessor, :continue)
  end

  @doc """
  Handles the process of check pending files, if exist run the process
  """
  @impl true
  def handle_info(:file_process, {files, true}), do: {:noreply, {files, true}}
  def handle_info(:file_process, {files, false}) do
    {files, processing} =
      case files do
        [file | rest] ->
          Task.Supervisor.async_nolink(CatalyxTest.Supervisor, CatalyxTest.CsvProcessor, :process_file, [file])
          {rest, true}
        [] ->
          {files, false}
      end

    {:noreply, {files, processing}}
  end

  defp schedule_file_check() do
    # check again in 2 seconds
    Process.send_after(self(), :file_process, 5  * 1000)
  end

  @spec process_file({String.t(), String.t()}) :: any()
  def process_file({bucket, object_key}) do
    IO.inspect("processing file")

#    continue_process()
  end
  
end