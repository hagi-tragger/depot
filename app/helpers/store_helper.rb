module StoreHelper

	def hidden_div_if(condition, attributes = {})
		if condition
			attributes["style"] = "display: none"
		end
		attrs = tag_options(attributes.stringify_keys)
		"<div #{attrs}>"
	end
end
