class Wrapper
  def wrap(opts)
    cols = opts[:cols]
    text = opts[:text]
  end

  def shell(text)
    text.shellsplit.inspect
  end
end

Wrapper.new.shell('poop')
