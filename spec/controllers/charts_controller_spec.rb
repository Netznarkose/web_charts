require 'rails_helper'

RSpec.describe ChartsController, type: :controller do
  let!(:chart) { Fabricate(:chart) }
  let!(:png_chart) { Fabricate(:chart, file_type: 'png') }
  let!(:valid_attributes) do
    {
      title: 'Chart title',
      colors: ['red', 'green'],
      data: {
        '1' => { column: [1,2,3] },
        '2' => { column: [4,5,6] }
      }
    }
  end
  let(:invalid_attributes) do
    {
      title: '',
      colors: ['red'],
      data: {
        '1' => { column: [1, 2] },
        '2' => { column: [4, 8] }
      }
    }
  end

  describe "GET #index" do
    it 'renders the index-template' do
      get :index
      expect(response).to be_success
    end
    it "assigns all charts as @charts" do
      Fabricate.times(4, :chart)
      charts = Chart.all
      get :index
      expect(assigns(:charts)).to eq(charts)
    end
  end

  describe 'GET #show' do
    it 'assigns requested chart as @chart' do
      get :show, id: chart.to_param
      expect(assigns(:chart)).to eq(chart)
    end
    it "renders the show-template" do
      get :show, id: chart.to_param
      expect(response).to render_template('show')
    end
  end

  describe 'Get #render_image' do
    context 'svg' do
      it 'returns svg' do
        get :render_image, id: chart.to_param
        expect(response.body).to match(/svg/)
      end
      it 'returns successfull status code for svg image' do
        get :render_image, id: chart.to_param
        expect(response).to be_success
      end
    end
    context 'png' do
      it 'returns successfull status code for png image' do
        get :render_image, id: png_chart.to_param
        expect(response).to be_success
      end
      it 'returns png' do
        get :render_image, id: png_chart.to_param
        expect(response.body).to match(/PNG/)
      end
    end
  end

  describe 'GET #new' do
    it 'assigns a new chart as @chart' do
      get :new, {}
      expect(assigns(:chart)).to be_a_new(Chart)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested post as @post' do
      get :edit, id: chart.to_param
      expect(assigns(:chart)).to eq(chart)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Chart' do
        expect {
          post :create, chart: valid_attributes
        }.to change(Chart, :count).by(1)
      end

      it 'assigns a newly created chart as @chart' do
        post :create, chart: valid_attributes
        expect(assigns(:chart)).to be_a(Chart)
        expect(assigns(:chart)).to be_persisted
      end

      it 'redirects to the created chart' do
        post :create, chart: valid_attributes
        expect(response).to redirect_to(edit_chart_path(Chart.last))
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved chart as @chart' do
        post :create, chart: invalid_attributes
        expect(assigns(:chart)).to be_a_new(Chart)
      end

      it "re-renders the 'new' template" do
        post :create, chart: invalid_attributes
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do

      it 'updates the requested chart' do
        put :update, id: chart.to_param, chart: { title: 'fabrication_clone' }
        chart.reload
        expect(chart.title).to eq('fabrication_clone')
      end

      it "assigns the requested chart as @chart" do
        put :update, { id: chart.to_param, chart: valid_attributes }
        expect(assigns(:chart)).to eq(chart)
      end

      it "redirects to the chart" do
        put :update, { id: chart.to_param, chart: valid_attributes }
        expect(response).to redirect_to(edit_chart_path(chart))
      end
    end

    # context "with invalid params" do
    # it "assigns the chart as @chart" do
    #   put :update, { id: chart.to_param, chart: invalid_attributes }
    #   expect(assigns(:chart)).to eq(chart)
    # end

    # it "re-renders the 'edit' template" do
    #   put :update, { id: chart.to_param, chart: invalid_attributes }
    #   expect(response).to render_template("edit")
    # end
    # end
  end

  describe "DELETE #destroy" do
    it "destroys the requested chart" do
      expect {
        delete :destroy, { id: chart.to_param }
      }.to change(Chart, :count).by(-1)
    end

    it "redirects to the charts list" do
      delete :destroy, { id: chart.to_param }
      expect(response).to redirect_to(charts_path)
    end
  end
  describe 'GET #download' do
    context 'svg selected' do
      it 'responses with the correct http-header' do
        get :download, id: chart.id
        expect(response).to be_successful
        expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"chart_title.svg\"")
      end
    end
    context 'png selected' do
      it 'responses with the correct http-header' do
        get :download, id: png_chart.id
        expect(response).to be_successful
        expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"chart_title.png\"")
      end
    end
  end
end
