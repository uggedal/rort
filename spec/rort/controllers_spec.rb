require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'controllers in general' do

  it 'should return a result' do
    res = Rack::MockRequest.new(@app).get('/')
    res.body.should =~ /^\{"body":\{".+\}$/
  end

  it 'should return the correct content type' do
    res = Rack::MockRequest.new(@app).get('/')
    res.headers["Content-Type"].should =='application/json'
  end

  it 'should allow requests from all' do
    accept = "text/xml,application/xml,application/xhtml+xml,
              text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0."
    res = Rack::MockRequest.new(@app).get('/', {"HTTP_ACCEPT" => accept})
    res.status.should == 200
  end

  it 'should return serializable json' do
    res = Rack::MockRequest.new(@app).get('/')
    hash = { 'application' => Rort.name, 'version' => Rort::VERSION }
    JSON.parse(res.body)['body'].should == hash
  end
end

describe Artists, 'controller' do

  it 'should show a given artist' do
    res = Rack::MockRequest.new(@app).get('/artists/uggedal')
    JSON.parse(res.body)['body'].should be_has_key('name')
  end
end

describe Favorites, 'controller' do

  it 'should list the favorites of an artist' do
    res = Rack::MockRequest.new(@app).get('/artists/uggedal/favorites')
    JSON.parse(res.body)['body'].size.should > 1
  end
end

describe Fans, 'controller' do

  it 'should list the fans of an artist' do
    res = Rack::MockRequest.new(@app).get('/artists/Katzenjammer/fans')
    JSON.parse(res.body)['body'].size.should > 120
  end
end

describe Friends, 'controller' do

  it 'should list the friends of an artist' do
    res = Rack::MockRequest.new(@app).get('/artists/uggedal/friends')
    JSON.parse(res.body)['body'].size.should > 250
  end
end
