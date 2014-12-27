local utils = require "apenode.utils"
local cjson = require "cjson"

local kProxyURL = "http://localhost:8000/"

describe("Proxy API #proxy", function()

  describe("Invalid API", function()
    it("should return API not found when the API is missing", function()
      local response, status, headers = utils.get(kProxyURL)
      local body = cjson.decode(response)
      assert.are.equal(404, status)
      assert.are.equal("API not found", body.message)
    end)
  end)

  describe("Existing API", function()

    it("should return API found when the API has been created", function()
      local response, status, headers = utils.get(kProxyURL .. "get", {}, {host = "test.com"})
      local body = cjson.decode(response)
      assert.are.equal(403, status)
      assert.are.equal("Your authentication credentials are invalid", body.message)
    end)

    describe("Query Authentication", function()
      it("should return invalid credentials when the credential value is wrong", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {apikey = "asd"}, {host = "test.com"})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should return invalid credentials when the credential parameter name is wrong in GET", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {apikey123 = "apikey123"}, {host = "test.com"})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should return invalid credentials when the credential parameter name is wrong in POST", function()
        local response, status, headers = utils.post(kProxyURL .. "post", {apikey123 = "apikey123"}, {host = "test.com"})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should pass with GET", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {apikey = "apikey123"}, {host = "test.com"})
        assert.are.equal(200, status)
        local parsed_response = cjson.decode(response)
        assert.are.equal("apikey123", parsed_response.args.apikey)
      end)
      it("should pass with POST", function()
        local response, status, headers = utils.post(kProxyURL .. "post", {apikey = "apikey123"}, {host = "test.com"})
        assert.are.equal(200, status)
        local parsed_response = cjson.decode(response)
        assert.are.equal("apikey123", parsed_response.form.apikey)
      end)
    end)

    describe("Header Authentication", function()
      it("should return invalid credentials when the credential value is wrong", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {}, {host = "test2.com", apikey = "asd"})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should return invalid credentials when the credential parameter name is wrong in GET", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {}, {host = "test2.com", apikey123 = "apikey123"})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should return invalid credentials when the credential parameter name is wrong in POST", function()
        local response, status, headers = utils.post(kProxyURL .. "post", {}, {host = "test2.com", apikey123 = "apikey123"})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should pass with GET", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {}, {host = "test2.com", apikey = "apikey123"})
        assert.are.equal(200, status)
        local parsed_response = cjson.decode(response)
        assert.are.equal("apikey123", parsed_response.headers.Apikey)
      end)
      it("should pass with POST", function()
        local response, status, headers = utils.post(kProxyURL .. "post", {}, {host = "test2.com", apikey = "apikey123"})
        assert.are.equal(200, status)
        local parsed_response = cjson.decode(response)
        assert.are.equal("apikey123", parsed_response.headers.Apikey)
      end)
    end)

    describe("Basic Authentication", function()

      it("should return invalid credentials when the credential value is wrong", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {}, {host = "test3.com", authorization = "asd"})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should return invalid credentials when the credential parameter name is wrong in GET", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {}, {host = "test3.com", authorization123 = "Basic dXNlcjEyMzphcGlrZXkxMjM="})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should return invalid credentials when the credential parameter name is wrong in POST", function()
        local response, status, headers = utils.post(kProxyURL .. "post", {}, {host = "test3.com", authorization123 = "Basic dXNlcjEyMzphcGlrZXkxMjM="})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should not pass when passing only the password", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {}, {host = "test3.com", authorization = "Basic OmFwaWtleTEyMw=="})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should not pass when passing only the username", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {}, {host = "test3.com", authorization = "Basic dXNlcjEyMzo="})
        local body = cjson.decode(response)
        assert.are.equal(403, status)
        assert.are.equal("Your authentication credentials are invalid", body.message)
      end)
      it("should pass with GET", function()
        local response, status, headers = utils.get(kProxyURL .. "get", {}, {host = "test3.com", authorization = "Basic dXNlcjEyMzphcGlrZXkxMjM="})
        assert.are.equal(200, status)
        local parsed_response = cjson.decode(response)
        assert.are.equal("Basic dXNlcjEyMzphcGlrZXkxMjM=", parsed_response.headers.Authorization)
      end)
      it("should pass with POST", function()
        local response, status, headers = utils.post(kProxyURL .. "post", {}, {host = "test3.com", authorization = "Basic dXNlcjEyMzphcGlrZXkxMjM="})
        assert.are.equal(200, status)
        local parsed_response = cjson.decode(response)
        assert.are.equal("Basic dXNlcjEyMzphcGlrZXkxMjM=", parsed_response.headers.Authorization)
      end)
    end)

  end)

end)