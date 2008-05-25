require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Rort::Http::Api do

  before(:each) do
    Rort::Models::Respondent.create_table!
    @respondent = Rort::Models::Respondent.create :email => 'eu@redflavor.com'
    @app = Rort::Http::Api.new
  end

  it 'should return success on valid request' do
    res = Rack::MockRequest.new(@app).
      get('/activities?email=eu@redflavor.com&slug=uggedal')
    res.body.should_not be_empty
    res.status.should == 200
  end

  it 'should return not found on invalid request' do
    res = Rack::MockRequest.new(@app).
      get('/activities?somepar=email@here.com&slug=uggedal')
    res.body.should be_empty
    res.status.should == 404

    res = Rack::MockRequest.new(@app).get('/path/here')
    res.body.should be_empty
    res.status.should == 404
  end

  it 'should return forbidden on nonexistant slug' do
    res = Rack::MockRequest.new(@app).
      get('/activities?email=no@name.com&slug=nonexistantname')
    res.body.should be_empty
    res.status.should == 403
  end

  it 'should return the correct content type' do
    res = Rack::MockRequest.new(@app).
      get('/activities?email=eu@redflavor.com&slug=uggedal')

    res = Rack::MockRequest.new(@app).
      get('/activities?email=no@name.com&slug=noname')
    res.headers["Content-Type"].should =='application/json'

    res = Rack::MockRequest.new(@app).get('/')
    res.headers["Content-Type"].should =='application/json'
  end

  it 'should show recent activity for all activities of an artist' do
    res = Rack::MockRequest.new(@app).
      get('/activities?email=eu@redflavor.com&slug=uggedal')
    JSON.parse(res.body).size.should > 1
  end

  it 'should increment and store slug when activities are showed' do
    Rort::Models::Respondent.find(:email => 'eu@redflavor.com').
      slug.should be_nil

    Rack::MockRequest.new(@app).
      get('/activities?email=eu@redflavor.com&slug=uggedal')
    Rort::Models::Respondent.find(:email => 'eu@redflavor.com').
      requests.should == 1
    Rort::Models::Respondent.find(:email => 'eu@redflavor.com').
      slug.should == 'uggedal'

    Rack::MockRequest.new(@app).
      get('/activities?email=eu@redflavor.com&slug=uggedal')
    Rort::Models::Respondent.find(:email => 'eu@redflavor.com').
      requests.should == 2
    Rort::Models::Respondent.find(:email => 'eu@redflavor.com').
      slug.should == 'uggedal'
  end

  it 'should show all favorites of an artist' do
    res = Rack::MockRequest.new(@app).
      get('/favorites?email=eu@redflavor.com&slug=uggedal')
    JSON.parse(res.body).size.should > 1
  end

  it 'should increment control respondent when favorites are showed' do
    Rort::Models::Respondent.find(:email => 'eu@redflavor.com').
      slug.should be_nil

    Rack::MockRequest.new(@app).
      get('/favorites?email=eu@redflavor.com&slug=uggedal')
    Rort::Models::Respondent.find(:email => 'eu@redflavor.com').
      requests.should == 1
    Rort::Models::Respondent.find(:email => 'eu@redflavor.com').
      slug.should == 'uggedal'

    Rack::MockRequest.new(@app).
      get('/favorites?email=eu@redflavor.com&slug=uggedal')
    Rort::Models::Respondent.find(:email => 'eu@redflavor.com').
      requests.should == 2
    Rort::Models::Respondent.find(:email => 'eu@redflavor.com').
      slug.should == 'uggedal'
  end
end
