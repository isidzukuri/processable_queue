# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProcessableQueue::Queue do
  ProcessableQueue::Config::DEFAULTS[:threads_pool][:thread_limit] = 2
  ProcessableQueue::Config::DEFAULTS[:max_job_time] = 2

  describe 'new' do
    let!(:processor) { proc {} }

    it 'acepts obj which responds to call as processor parameter' do
      expect(described_class.new(processor)).to be_a(described_class)
    end
  end

  describe 'push' do
    class DummyProcessor
      attr_reader :store

      def initialize
        @store = []
      end

      def call(item)
        @store << item
      end
    end

    let!(:dummy_processor) { DummyProcessor.new }
    let!(:obj) { described_class.new(dummy_processor) }
    let!(:item) { 1 }

    it 'ads item to internal store' do
      expect(obj.queue.size).to eq(0)

      obj.push(item)
      expect(obj.process).to eq true

      expect(obj.queue.size).to eq(1)
      expect(dummy_processor.store).to eq([item])
    end

    it 'starts processing not processed items' do
      expect_any_instance_of(DummyProcessor).to receive(:call).with(item)

      obj.push(item)
      expect(obj.process).to eq true
    end

    context 'slow processor' do
      class SlowDummyProcessor
        attr_reader :store

        def initialize
          @store = []
        end

        def call(item)
          sleep(0.1)
          @store << item
        end
      end

      let!(:dummy_processor) { SlowDummyProcessor.new }
      let!(:obj) { described_class.new(dummy_processor) }
      let!(:items) { [1, 2, 3, 4] }
      let!(:late_item) { 5 }

      it '' do
        obj.push(items)
        expect(obj.process).to eq true

        expect(obj.queue.size).to eq(4)
      end

      it '' do
        obj.push(items)
        expect(obj.process).to eq true

        obj.push(late_item)

        expect(obj.queue.size).to eq(5)
      end
    end

    context 'slow processor adds more items into queue' do
      class SlowProcessor
        attr_accessor :store, :queue

        def initialize
          @store = []
          @work_added = false
        end

        def call(item)
          sleep(1)
          @store << item
          return if @work_added

          add_work
          @work_added = true
        end

        def add_work
          queue.push([91, 92, 93, 94, 95, 96, 97])
        end
      end

      let!(:items) { [1, 2, 3, 4] }

      it 'processes items added later' do
        processor = SlowProcessor.new
        obj = described_class.new(processor)
        processor.queue = obj

        expect_any_instance_of(ProcessableQueue::ThreadsPool).to receive(:join).exactly(1).and_call_original

        obj.push(items)
        expect(obj.process).to eq true

        expect(obj.queue.size).to eq(11)
      end
    end
  end

  describe '#process' do
    context 'one item raises error while processing' do
      let!(:items) { [1, 2, 3, 4, 5, 6, 7, 8] }

      class BugProcessor
        TestError = Class.new(StandardError)

        attr_accessor :store, :queue, :processed

        def initialize
          @store = []
          @processed = []
        end

        def call(item)
          raise TestError if item == 5

          @processed << item
        end
      end

      it 'rescues error and logs it' do
        processor = BugProcessor.new
        obj = described_class.new(processor)
        processor.queue = obj

        expect_any_instance_of(ProcessableQueue::ThreadsPool).to receive(:join).exactly(1).and_call_original
        expect(ProcessableQueue::Log).to receive(:puts_alert).and_call_original

        obj.push(items)
        expect(obj.process).to eq true

        expect(obj.queue.size).to eq(8)
        expect(processor.processed.size).to eq(7)
        expect(processor.processed).to eq([1, 2, 3, 4, 6, 7, 8])
        expect(obj.errors.size).to eq 1
        expect(obj.errors[0][:item]).to eq 5
        expect(obj.errors[0][:error]).to eq 'BugProcessor::TestError: BugProcessor::TestError'
        expect(obj.errors[0][:backtrace]).to be_a(String)
      end
    end

    context 'one item raises error while processing' do
      let!(:items) { [1] }

      class ExtraSlowProcessor
        attr_accessor :store, :queue

        def initialize
          @store = []
          @raised = false
        end

        def call(_item)
          sleep(3)
        end
      end

      it 'rescues error and logs it' do
        processor = ExtraSlowProcessor.new
        obj = described_class.new(processor)
        processor.queue = obj

        expect_any_instance_of(ProcessableQueue::ThreadsPool).to receive(:join).exactly(1).and_call_original
        expect(ProcessableQueue::Log).to receive(:puts_alert).and_call_original

        obj.push(items)
        expect(obj.process).to eq true

        expect(obj.queue.size).to eq(1)
      end
    end
  end
end
