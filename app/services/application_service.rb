class ApplicationService
  class << self
    def call!(*args)
      new.call!(*args)
    end

    def call(*args)
      new.call(*args)
    end
  end

  def call!(*_args)
    raise NotImplementedError, 'Abstract class: you must implement #call!'
  end

  def call(*args)
    call!(*args)
  rescue StandardError => exception
    Rails.logger.warn exception
    nil
  end
end
