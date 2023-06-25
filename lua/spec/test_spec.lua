describe('sample tests', function()
    it ('should pass', function ()
        assert.is_true(true)
    end)

    it ('should work', function ()
        local tbl = vim.tbl_deep_extend('force', { hello = 10 }, { world = 20 })
        assert.are.same(tbl, { hello = 10, world = 20 })
    end)

    it ('should fail', function ()
        assert.is_true(false)
    end)
end)