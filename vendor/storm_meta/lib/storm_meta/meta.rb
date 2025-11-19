module StormMeta
  module Meta
    def dynamic_attr(*names)
      names.each do |name|
        define_method(name) do
          instance_variable_get("@#{name}")
        end

        define_method("#{name}=") do |value|
          instance_variable_set("@#{name}", value)
        end
      end
    end

    def boolean_flags(*names)
      names.each do |name|
        define_method("#{name}?") do
          !!instance_variable_get("@#{name}")
        end

        define_method("#{name}!") do
          instance_variable_set("@#{name}", true)
        end

        define_method("not_#{name}!") do
          instance_variable_set("@#{name}", false)
        end
      end
    end

    def dsl(&block)
      class_eval(&block)
    end
  end
end