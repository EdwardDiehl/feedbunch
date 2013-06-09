require 'spec_helper'

describe 'start page' do

  before :each do
    @user = FactoryGirl.create :user
    @feed1 = FactoryGirl.create :feed
    @user.feeds << @feed1
    @entry1 = FactoryGirl.build :entry, feed_id: @feed1.id
    @feed1.entries << @entry1

    login_user_for_feature @user
    visit feeds_path
  end

  it 'shows start page by default', js: true do
    page.should have_css '#start-info'
    page.should have_css '#feed-entries.hidden', visible: false
  end

  it 'hides feed title and entries by default', js: true do
    page.should have_css '#feed-title.hidden', visible: false
    page.should have_css '#feed-entries.hidden', visible: false
  end

  it 'hides refresh, unsubscribe and folder management buttons by default', js: true do
    page.should have_css '#refresh-feed.hidden', visible: false
    page.should have_css '#unsubscribe-feed.hidden', visible: false
    page.should have_css '#folder-management.hidden', visible: false
  end

  it 'hides start page when reading a feed', js: true do
    page.should have_css '#start-info'
    page.should have_css '#feed-entries.hidden', visible: false

    read_feed @feed1.id

    page.should have_css '#start-info.hidden', visible: false
    page.should have_css '#feed-entries'
  end

  context 'click on Start link' do

    before :each do
      # click on a feed, then click on the Start link
      read_feed @feed1.id
      sleep 1
      find('#start-page').click
      sleep 1
    end

    it 'shows start page', js: true do
      page.should have_css '#start-info'
      page.should have_css '#feed-entries.hidden', visible: false
    end

    it 'hides feed title and entries', js: true do
      page.should have_css '#feed-title.hidden', visible: false
      page.should have_css '#feed-entries.hidden', visible: false
    end

    it 'hides refresh, unsubscribe and folder management buttons', js: true do
      page.should have_css '#refresh-feed.hidden', visible: false
      page.should have_css '#unsubscribe-feed.hidden', visible: false
      page.should have_css '#folder-management.hidden', visible: false
    end

  end


end