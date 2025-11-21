import React from 'react';
import { sanitizeHtml } from '../utils/sanitize';

/**
 * SafeHtml Component
 * 
 * Use this component when you need to render HTML content from user input or external sources.
 * It automatically sanitizes the content to prevent XSS attacks.
 * 
 * @example
 * <SafeHtml content={userGeneratedHtml} />
 * 
 * @example With custom className
 * <SafeHtml content={notes} className="prose" />
 */
const SafeHtml = ({ content, className = '', ...props }) => {
  if (!content) return null;
  
  const sanitized = sanitizeHtml(content);
  
  return (
    <div
      className={className}
      dangerouslySetInnerHTML={{ __html: sanitized }}
      {...props}
    />
  );
};

export default SafeHtml;



