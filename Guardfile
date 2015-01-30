group :doc do
  guard :shell do

    watch 'config.ld' do
      `ldoc .`
    end

    watch %r(^*.lua$) do |m|
      `ldoc .`
    end
  end
end

group :spec do
  guard :shell do
    watch %r(^spec/*_spec\.lua$) do |m|
      `busted #{m}`
    end

    watch %r(^*.lua$) do |m|
      `busted`
    end
  end
end
