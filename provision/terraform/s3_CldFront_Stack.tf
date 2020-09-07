data "aws_iam_policy_document" "s3-web-policy" {
    statement {
        sid = "PublicReadGetObject"
        effect = "Allow"
        actions = [
                "s3:GetObject"
        ]
        resources   = [
            "arn:aws:s3:::${var.site_name}/*"
        ]
        principals  {
            type    = "AWS"
            identifiers = [
                "*"
            ]
            
        }
    }
}

resource "aws_s3_bucket" "s3-hexo-bucket" {
    bucket          = var.site_name
    force_destroy   = true
    acl             = "public-read"
    policy          = data.aws_iam_policy_document.s3-web-policy.json
    
    website {
        index_document  = "index.html"
        error_document  = "error.html"
    }
}

# Find a certificate issued by (not imported into) ACM
data "aws_acm_certificate" "ssl-hosted-certificate" {
    provider    = aws.virginia 
    domain      = var.acm_domain
    types       = ["AMAZON_ISSUED"]
    most_recent = true
}

resource "aws_cloudfront_distribution" "site_distribution" {

    origin {
        domain_name = aws_s3_bucket.s3-hexo-bucket.website_endpoint
        origin_id = var.origin_name

        custom_origin_config {
                http_port              = "80"
                https_port             = "443"
                origin_protocol_policy = "http-only"
                origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
    }
    
    

    enabled = true
    
    aliases = [var.site_name]
    
    price_class = "PriceClass_100"
    
    default_root_object = "index.html"
    
    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH",
                      "POST", "PUT"]
        cached_methods      = ["GET", "HEAD"]
        target_origin_id    = var.origin_name 
        
        forwarded_values {
            query_string = true
            cookies {
                forward = "all"
            }
        }
        
        viewer_protocol_policy  = "https-only"
        min_ttl                 = 0
        default_ttl             = 1000
        max_ttl                 = 86400
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn = data.aws_acm_certificate.ssl-hosted-certificate.arn
        minimum_protocol_version = "TLSv1.1_2016"
        ssl_support_method = "sni-only"
    }
}

# Access to our route53 available zone
data "aws_route53_zone" "main_zone" {
    name = var.acm_domain
}

# Creates an A record
resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.main_zone.zone_id
  name  = var.site_name
  type  = "A"

  alias {
      name  = aws_cloudfront_distribution.site_distribution.domain_name
      zone_id   = aws_cloudfront_distribution.site_distribution.hosted_zone_id
      evaluate_target_health  = false
  }
}