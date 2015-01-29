guard :shell do  
  watch %r(^*.lua$) do |m|
    `busted`
  end

  watch %r(^spec/*_spec\.lua$) do |m|
    `busted #{m}`
  end
end
