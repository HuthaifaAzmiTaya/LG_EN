class ApisController < ApplicationController
    def test
        puts "Test action called"
        render json: { message: "API is working!" }
    end
end
