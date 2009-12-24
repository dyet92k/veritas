require File.expand_path('../../../../../spec_helper', __FILE__)

describe 'Veritas::Relation::Body#header' do
  before do
    @header = mock('Header')

    @body = Relation::Body.new(@header, [ [ 1 ] ])
  end

  subject { @body.header }

  it { should equal(@header) }
end
