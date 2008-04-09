require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'controllers in general' do

  it 'should return a result' do
    res = Rack::MockRequest.new(@app).get('/greet')
    res.body.should =~ /^\{"body":\{ "id.+\}$/
  end

  it 'should return the correct content type' do
    res = Rack::MockRequest.new(@app).get('/greet')
    res.headers["Content-Type"].should =='application/json'
  end

  it 'should allow requests from all' do
    accept = "text/xml,application/xml,application/xhtml+xml,
              text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0."
    res = Rack::MockRequest.new(@app).get('/greet', {"HTTP_ACCEPT" => accept})
    res.status.should == 200
  end
end
