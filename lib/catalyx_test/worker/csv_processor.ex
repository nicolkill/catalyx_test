defmodule CatalyxTest.CsvProcessor do
  use GenServer

  alias CatalyxTest.AWS.S3Client

  @downloads_folder "downloads"

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

  @impl true
  def handle_call(:lookup, _, state), do: {:reply, state, state}

  def lookup() do
    GenServer.call(CsvProcessor, :lookup)
  end

  @impl true
  def handle_cast({:add, file_path}, {files, processing}) do
    {:noreply, {[file_path | files], processing}}
  end

  def handle_cast(:continue, {files, _}) do
    {:noreply, {files, false}}
  end

  def schedule_file(file_path) do
    GenServer.cast(CsvProcessor, {:add, file_path})
  end

  defp continue_checking() do
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
        [file_path | rest] ->
          Task.async(__MODULE__, :process_file, [file_path])
          {rest, true}

        [] ->
          {files, false}
      end

    schedule_file_check()

    {:noreply, {files, processing}}
  end

  def handle_info(_, {files, processing}), do: {:noreply, {files, processing}}

  defp schedule_file_check() do
    # check again in 5 seconds
    Process.send_after(self(), :file_process, 5 * 1000)
  end

  @spec process_file(String.t()) :: any()
  def process_file(s3_path) do
    try do
      :ok = S3Client.does_object_exist(s3_path)

      file_path =
        :catalyx_test
        |> :code.priv_dir()
        |> (&"#{&1}/#{@downloads_folder}/#{s3_path}").()

      :ok =
        case S3Client.download_object(s3_path, file_path) do
          {:ok, :done} -> :ok
          _ -> :error
        end

      File.stream!(file_path)
      |> Stream.chunk_every(30)
      |> Stream.map(&process_chunk/1)
      |> Stream.run()
    rescue
      _ ->
        :ok
    end

    continue_checking()
  end

  defp process_chunk(chunk) do
    chunk
    |> Enum.flat_map(fn
      "id,market" <> _ ->
        []

      part ->
        data =
          part
          |> String.trim()
          |> String.split(",")

        [data]
    end)
    |> Enum.reduce(Ecto.Multi.new(), fn row, transaction ->
      [external_id, market_symbol, size, price, taker_side, executed_at] = row

      date_time = NaiveDateTime.from_iso8601!(executed_at)

      changeset =
        CatalyxTest.Finances.new_change_trade(%{
          market_symbol: market_symbol,
          amount: size,
          price: price,
          transaction_type: taker_side,
          executed_at_date: NaiveDateTime.to_date(date_time),
          executed_at_time: NaiveDateTime.to_time(date_time),
          external_id: external_id
        })

      Ecto.Multi.insert(transaction, "#{market_symbol}_#{external_id}", changeset)
    end)
    |> CatalyxTest.Repo.transaction()
  end
end
