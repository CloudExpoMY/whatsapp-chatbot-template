class ApplicationController < ActionController::Base
  ActiveAdmin::ResourceController.class_eval do
    def permitted_params
      params.permit!
    end
  end
end
