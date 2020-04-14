before do
  allow_any_instance_of(ApplicationController).to receive(:is_login?).and_return(true)
end