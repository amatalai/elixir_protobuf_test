# ElixirProtobufTest

Submodule that allow us to check if protobuf definitions are compiled properly in elixir.

**This probably won't work for you**

## CI setup

```
  script:
    - apt-get update
    - apt-get install -y ruby-full
    - "./compile-elixir.sh"
    - cd elixir_protobuf_test
    - mix deps.get
    - mix test
    - mix load_protobufs
```
