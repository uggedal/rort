require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Rort::Http do

  before(:each) do
    @app = Rort::Http.new
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

  it 'should return forbidden on nonexistant username' do
    res = Rack::MockRequest.new(@app).get('?favorites=nonexistentusername')
    res.body.should be_empty
    res.status.should == 403
  end

  it 'should return the correct content type' do
    res = Rack::MockRequest.new(@app).get('?favorites=NoFavorites')
    res.headers["Content-Type"].should =='application/json'

    res = Rack::MockRequest.new(@app).get('/')
    res.headers["Content-Type"].should =='text/html'
  end

  it 'should show recent activity for all favorites of an artist' do
    res = Rack::MockRequest.new(@app).get('?favorites=uggedal')
    JSON.parse(res.body).size.should > 1
  end

  it 'should show a download form on unparamterized request' do
    res = Rack::MockRequest.new(@app).get('/')
    res.status.should == 200
    res.body.should =~ /form/
  end

  it 'should provide link to userscript when a valid email is provided' do
    res = Rack::MockRequest.new(@app).get('?download=eu@redflavor.com')
    res.status.should == 200
    res.body.should =~ /installeres/
  end

  it 'should provide userscript download' do
    res = Rack::MockRequest.new(@app).get('/rort.user.js')
    res.body.should =~ /==UserScript==/
  end

  it 'should show error when an invalid email is provided' do
    res = Rack::MockRequest.new(@app).get('?download=invalid@email')
    res.status.should == 200
    res.body.should =~ /Ugyldig/
  end
end
