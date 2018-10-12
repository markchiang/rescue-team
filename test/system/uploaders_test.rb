require "application_system_test_case"

class UploadersTest < ApplicationSystemTestCase
  setup do
    @uploader = uploaders(:one)
  end

  test "visiting the index" do
    visit uploaders_url
    assert_selector "h1", text: "Uploaders"
  end

  test "creating a Uploader" do
    visit uploaders_url
    click_on "New Uploader"

    fill_in "Content", with: @uploader.content
    fill_in "Time", with: @uploader.time
    click_on "Create Uploader"

    assert_text "Uploader was successfully created"
    click_on "Back"
  end

  test "updating a Uploader" do
    visit uploaders_url
    click_on "Edit", match: :first

    fill_in "Content", with: @uploader.content
    fill_in "Time", with: @uploader.time
    click_on "Update Uploader"

    assert_text "Uploader was successfully updated"
    click_on "Back"
  end

  test "destroying a Uploader" do
    visit uploaders_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Uploader was successfully destroyed"
  end
end
