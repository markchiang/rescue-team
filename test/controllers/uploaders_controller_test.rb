require 'test_helper'

class UploadersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @uploader = uploaders(:one)
  end

  test "should get index" do
    get uploaders_url
    assert_response :success
  end

  test "should get new" do
    get new_uploader_url
    assert_response :success
  end

  test "should create uploader" do
    assert_difference('Uploader.count') do
      post uploaders_url, params: { uploader: { content: @uploader.content, time: @uploader.time } }
    end

    assert_redirected_to uploader_url(Uploader.last)
  end

  test "should show uploader" do
    get uploader_url(@uploader)
    assert_response :success
  end

  test "should get edit" do
    get edit_uploader_url(@uploader)
    assert_response :success
  end

  test "should update uploader" do
    patch uploader_url(@uploader), params: { uploader: { content: @uploader.content, time: @uploader.time } }
    assert_redirected_to uploader_url(@uploader)
  end

  test "should destroy uploader" do
    assert_difference('Uploader.count', -1) do
      delete uploader_url(@uploader)
    end

    assert_redirected_to uploaders_url
  end
end
