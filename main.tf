# Create S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.my_bucket
}

# Disable Public Access Block (Allow Public Policy)
resource "aws_s3_bucket_public_access_block" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Public Read Bucket Policy (Modern Way)
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}

# Upload index.html
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

# Upload error.html
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
}

# Upload profile image
resource "aws_s3_object" "profile" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "profile.png"
  source       = "profile.png"
  content_type = "image/png"
}

# Static Website Hosting
resource "aws_s3_bucket_website_configuration" "website" {
  depends_on = [aws_s3_bucket_policy.public_read]

  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}