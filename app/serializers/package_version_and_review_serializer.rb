class PackageVersionAndReviewSerializer < PackageVersionSerializer
	has_one :review, embed_in_root: true
end
