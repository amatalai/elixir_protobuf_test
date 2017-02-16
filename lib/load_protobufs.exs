Path.expand("../../build-elixir", __DIR__)
|> File.ls!
|> Enum.reject(fn(filename) ->
  !String.match?(filename, ~r/.+\.proto/) || filename == "objectivec-descriptor.proto"
end)
|> Enum.map(&String.replace_suffix(&1, ".proto", ""))
|> Enum.each(fn(name) ->
  module_name = Module.concat("LoadProtobufs", Macro.camelize(name))
  content = quote do
    use Protobuf, from: Path.expand("../../build-elixir/#{unquote(name)}.proto", __DIR__)
  end

  Module.create(module_name, content, Macro.Env.location(__ENV__))
end)
