defmodule ProtobufTestTest do
  use ExUnit.Case

  @namespace ~r/(.*\s)([a-z]\w+\.)(.*)/
  @marked_namespace ~r/\/\/NAMESPACE$/
  @comment ~r/^\s*(\/\*\*|\*|\/\/)/
  @ignored_keywords ~r/^\s*(package|extend)/

  defp make_assertion(list) do
    assert length(list) == 0, Enum.join(list, "")
  end

  defp valid_line?(line) do
    cond do
      String.match?(line, @comment) ->
        {:ok, line}
      String.match?(line, @ignored_keywords) ->
        {:ok, line}
      !String.match?(line, @namespace) ->
        {:ok, line}
      String.match?(line, @marked_namespace) ->
        {:ok, line}
      :else ->
        {:error, line}
    end
  end

  defp validate_proto_file(filename) do
    Path.expand("../../messages/#{filename}", __DIR__)
    |> File.stream!
    |> Stream.chunk(1)
    |> Enum.map(&to_string(&1))
    |> Enum.map(&valid_line?(&1))
    |> Enum.reduce([], fn({status, line}, acc) ->
      if status == :error, do: acc ++ [line], else: acc
    end)
    |> make_assertion
  end

  test "comments are ignored" do
    comment1 = "// namespace.FeedEntry"
    comment2 = """
    /**
    * namespace.FeedEntry
    **/
    """

    assert {:ok, _} = valid_line?(comment1)
    assert {:ok, _} = valid_line?(comment2)
  end

  test "line is valid when doesn't contain namespace" do
    line1 = "repeated Nested.FeedEntry feed_entries = 1;\n"
    line2 = "repeated FeedEntry feed_entries = 1;\n"

    assert {:ok, _} = valid_line?(line1)
    assert {:ok, _} = valid_line?(line2)
  end

  test "line is valid when namespace is marked" do
    line = "repeated timeline_post.FeedEntry feed_entries = 1; //NAMESPACE"

    assert {:ok, _} = valid_line?(line)
  end

  test "line is invalid when namespace isn't marked" do
    line = "repeated timeline_post.FeedEntry feed_entries = 1;"

    assert {:error, _} = valid_line?(line)
  end

  Path.expand("../../messages", __DIR__)
  |> File.ls!
  |> Enum.reject(fn(filename) -> !String.match?(filename, ~r/.+\.proto/) end)
  |> Enum.each(fn(filename) ->
    test "#{filename} is valid" do

      validate_proto_file(unquote(filename))
    end
  end)
end
