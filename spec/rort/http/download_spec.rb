require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Rort::Http::Download do

  before(:each) do
    Rort::Models::Respondent.create_table!
    @app = Rort::Http::Download.new
  end

  it 'should return success on valid request' do
    res = Rack::MockRequest.new(@app).get('/')
    res.body.should_not be_empty
    res.status.should == 200
  end

  it 'should return not found on invalid request' do
    res = Rack::MockRequest.new(@app).get('/path/here')
    res.body.should be_empty
    res.status.should == 404
  end

  it 'should return the correct content type' do
    res = Rack::MockRequest.new(@app).get('/')
    res.headers["Content-Type"].should =='text/html'

    res = Rack::MockRequest.new(@app).get('/install/s@s.no/rort.user.js')
    res.headers["Content-Type"].should =='application/javascript'
  end

  it 'should show a download form on unparamterized request' do
    res = Rack::MockRequest.new(@app).get('/')
    res.status.should == 200
    res.body.should =~ /form/
  end

  it 'should provide link to userscript when a valid email is provided' do
    res = Rack::MockRequest.new(@app).
            post("/", :input => "email=eu@redflavor.com")
    res.status.should == 200
    res.body.should =~ /installeres/
  end

  it 'should provide link to userscript depending on group' do
    res = Rack::MockRequest.new(@app).
            post("/", :input => "email=1@redflavor.com")
    res.status.should == 200
    res.body.should =~ /\/rort\.user\.js/
    Rort::Models::Respondent.find(:email => '1@redflavor.com').group.
      should == 'experiment'

    res = Rack::MockRequest.new(@app).
            post("/", :input => "email=2@redflavor.com")
    res.status.should == 200
    res.body.should =~ /\/urort\.user\.js/
    Rort::Models::Respondent.find(:email => '2@redflavor.com').group.
      should == 'control'

    res = Rack::MockRequest.new(@app).
            post("/", :input => "email=3@redflavor.com")
    res.status.should == 200
    res.body.should =~ /\/rort\.user\.js/
    Rort::Models::Respondent.find(:email => '3@redflavor.com').group.
      should == 'experiment'

    res = Rack::MockRequest.new(@app).
            post("/", :input => "email=4@redflavor.com")
    res.status.should == 200
    res.body.should =~ /\/urort\.user\.js/
    Rort::Models::Respondent.find(:email => '4@redflavor.com').group.
      should == 'control'
  end

  it 'should provide control group userscript download' do
    res = Rack::MockRequest.new(@app).get('/install/s@s.no/urort.user.js')
    res.body.should =~ /==UserScript==/
    res.body.should =~ /Dine favoritter/
  end

  it 'should provide experiment group userscript download' do
    res = Rack::MockRequest.new(@app).get('/install/s@s.no/rort.user.js')
    res.body.should =~ /==UserScript==/
    res.body.should =~ /Siste fra dine Favoritter/
  end

  it 'should show error when an invalid email is provided' do
    res = Rack::MockRequest.new(@app).
            post("/", :input => "email=redflavor.com")
    res.status.should == 200
    res.body.should =~ /Ugyldig/
  end
end
