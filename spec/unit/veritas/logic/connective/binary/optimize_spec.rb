require 'spec_helper'
require File.expand_path('../fixtures/classes', __FILE__)

describe 'Veritas::Logic::Connective::Binary#optimize' do
  subject { object.optimize }

  let(:klass)          { Class.new(BinarySpecs::Object) }
  let(:attribute)      { Attribute::Integer.new(:id)    }
  let(:original_left)  { attribute.gt(1)                }
  let(:original_right) { attribute.lt(1)                }
  let(:object)         { klass.new(left, right)         }

  context 'left and right are the same' do
    let(:left)  { attribute.gt(1) }
    let(:right) { attribute.gt(1) }

    it { should equal(left) }

    it_should_behave_like 'an optimize method'
  end

  context 'left and right are the same, after optimizing the left' do
    let(:left)  { original_left.and(Logic::Proposition::True.instance) }
    let(:right) { attribute.gt(1)                                      }

    it { should equal(original_left) }

    it_should_behave_like 'an optimize method'
  end

  context 'left and right are the same, after optimizing the right' do
    let(:left)  { attribute.gt(1)                                        }
    let(:right) { attribute.gt(1).and(Logic::Proposition::True.instance) }

    it { should equal(left) }

    it_should_behave_like 'an optimize method'
  end

  context 'left and right are different' do
    let(:left)  { attribute.gt(1) }
    let(:right) { attribute.lt(1) }

    it { should equal(object) }

    it_should_behave_like 'an optimize method'
  end

  context 'left and right are different, after optimizing the left' do
    let(:left)  { original_left.and(Logic::Proposition::True.instance) }
    let(:right) { attribute.lt(1)                                      }

    add_method_missing

    it { should_not equal(object) }

    it { should be_instance_of(klass) }

    its(:left) { should equal(original_left) }

    its(:right) { should equal(right) }

    it_should_behave_like 'an optimize method'
  end

  context 'left and right are different, after optimizing the right' do
    let(:left)  { attribute.gt(1)                                       }
    let(:right) { original_right.and(Logic::Proposition::True.instance) }

    add_method_missing

    it { should_not equal(object) }

    it { should be_instance_of(klass) }

    its(:left) { should equal(left) }

    its(:right) { should equal(original_right) }

    it_should_behave_like 'an optimize method'
  end

  context 'self and right are the same, and left and right.left are the same' do
    let(:left)  { attribute.eq(1)                                                     }
    let(:right) { mock('Binary', :class => klass, :left => left, :optimized? => true) }

    before do
      right.stub!(:optimize => right, :frozen? => true)
    end

    it { should equal(right) }

    it_should_behave_like 'an optimize method'
  end

  context 'self and left are the same, and right and left.right are the same' do
    let(:left)  { mock('Binary', :class => klass, :right => right, :optimized? => true) }
    let(:right) { attribute.eq(1)                                                       }

    before do
      left.stub!(:optimize => left, :frozen? => true)
    end

    it { should equal(left) }

    it_should_behave_like 'an optimize method'
  end

  context 'left and right are always true' do
    let(:left)  { mock('Left') }
    let(:right) { mock('Right') }

    before do
      left.stub!(:optimize).and_return(left)
      right.stub!(:optimize).and_return(right)

      klass.class_eval do
        def always_true?
          true
        end
      end
    end

    it { should equal(Logic::Proposition::True.instance) }
  end

  context 'left and right are always false' do
    let(:left)  { mock('Left') }
    let(:right) { mock('Right') }

    before do
      left.stub!(:optimize).and_return(left)
      right.stub!(:optimize).and_return(right)

      klass.class_eval do
        def always_false?
          true
        end
      end
    end

    it { should equal(Logic::Proposition::False.instance) }
  end
end
