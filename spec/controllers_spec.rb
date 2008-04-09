require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'controllers in general' do

  it 'should return a result' do
    res = Rack::MockRequest.new(@app).get('/greet')
    res.body.should =~ /^\{"body":\{.+\}$/
  end

  it 'should return a result' do
    res = Rack::MockRequest.new(@app).get('/greet')
    res.headers["Content-Type"].should =='application/json'
  end
end
