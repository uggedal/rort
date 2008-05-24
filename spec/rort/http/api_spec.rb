require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Rort::Http::Api do

  before(:each) do
    @app = Rort::Http::Api.new
  end

  it 'should return success on valid request' do
    res = Rack::MockRequest.new(@app).get('?favorites=NoFavorites')
    res.body.should_not be_empty
    res.status.should == 200
  end

  it 'should return not found on invalid request' do
    res = Rack::MockRequest.new(@app).get('?somepar=ohaha')
    res.body.should be_empty
    res.status.should == 404

    res = Rack::MockRequest.new(@app).get('/path/here')
    res.body.should be_empty
    res.status.should == 404
  end

  it 'should return forbidden on nonexistant slug' do
    res = Rack::MockRequest.new(@app).get('?favorites=nonexistentslug')
    res.body.should be_empty
    res.status.should == 403
  end

  it 'should return the correct content type' do
    res = Rack::MockRequest.new(@app).get('?favorites=NoFavorites')
    res.headers["Content-Type"].should =='application/json'

    res = Rack::MockRequest.new(@app).get('/')
    res.headers["Content-Type"].should =='application/json'
  end

  it 'should show recent activity for all favorites of an artist' do
    res = Rack::MockRequest.new(@app).get('?favorites=uggedal')
    JSON.parse(res.body).size.should > 1
  end
end
