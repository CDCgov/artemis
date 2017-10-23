require 'rails_helper'

class FizzBuzzService < ApplicationService
  def call!(num)
    raise ArgumentError, 'only integers' unless num.is_a? Integer
    text = ''
    text << 'Fizz' if num % 3 == 0
    text << 'Buzz' if num % 5 == 0
    text = num.to_s if text.empty?
    text
  end
end

RSpec.describe ApplicationService, type: :service do
  it 'raises errors for abstract class method' do
    error = NotImplementedError
    expect { described_class.call! }.to raise_error(error)
    expect { described_class.call }.to raise_error(error)
    expect { subject.call! }.to raise_error(error)
    expect { subject.call }.to raise_error(error)
  end

  context 'when inherited by a valid subclass' do
    let(:subclass) { FizzBuzzService }

    describe '.call!' do
      it 'calls the default instance #call! method' do
        expect(subclass.call!(3)).to eq 'Fizz'
      end

      it 'raises on error' do
        expect { subclass.call! 42.0 }.to raise_error(ArgumentError)
      end
    end

    describe '.call' do
      it 'calls the default instance #call method' do
        expect(subclass.call(5)).to eq 'Buzz'
      end

      it 'does not raise on error' do
        expect { subclass.call 42.0 }.to_not raise_error
      end
    end
  end
end
