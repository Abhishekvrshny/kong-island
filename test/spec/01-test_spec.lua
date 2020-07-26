local helpers = require "spec.helpers"

for _, strategy in helpers.each_strategy() do
  describe(": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp, db = helpers.get_db_utils(strategy, nil, { "myplugin" })

      -- Inject a test route. No need to create a service, there is a default
      -- service which will echo the request.
      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })
      -- add consumers

      local anonymous_user = bp.consumers:insert {
        username = "no-body",
      }

      local consumer = bp.consumers:insert {
        username = "bob",
      }

      -- add the plugins to test to the route we created
      bp.plugins:insert {
        name     = "myplugin",
        route = { id = route1.id },
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "myplugin",
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)

    describe("Unauthenticated :", function()

      it("send request without Authorization header", function()
        local r = client:get("/request", {
          headers = {
            host = "test1.com"
          }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
      end)
    end)
  end)

end

