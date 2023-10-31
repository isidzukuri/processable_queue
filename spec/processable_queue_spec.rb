# frozen_string_literal: true

RSpec.describe ProcessableQueue do
  it "has a version number" do
    expect(ProcessableQueue::VERSION).not_to be nil
  end

  describe '.call' do
    let(:processor) { proc {} }
    let(:items) { [1,2,3] }

    it 'processes each given item with given processer' do
      expect(processor).to receive(:call).with(1).ordered
      expect(processor).to receive(:call).with(2).ordered
      expect(processor).to receive(:call).with(3).ordered

      expect(ProcessableQueue.process(processor, items)).to eq true
    end
  end
end
