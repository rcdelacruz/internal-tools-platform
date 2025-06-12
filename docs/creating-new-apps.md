# Creating New Apps

> Guide for creating new Next.js applications in the Internal Tools Platform

## 🎯 Overview

This guide walks you through creating new self-contained Next.js applications that integrate with the shared services platform. Each application follows consistent patterns and can be developed, deployed, and scaled independently.

## 📋 Prerequisites

- Platform development environment set up (`npm run setup:dev`)
- Understanding of shared services architecture
- Familiarity with Next.js and TypeScript

## 🚀 Quick Start

### Using the App Generator

```bash
# Create a new application
npm run create:app skills-assessment

# This creates a complete Next.js application with:
# - Pre-configured shared services integration
# - Authentication setup
# - Database configuration
# - Docker setup
# - Testing framework
# - Development scripts
```

### Manual Creation Process

If you prefer to understand the full process:

#### 1. Create Directory Structure

```bash
mkdir -p apps/skills-assessment/src/{app,components,lib,types}
cd apps/skills-assessment
```

#### 2. Initialize Package

```json
{
  "name": "skills-assessment",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3003",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:e2e": "playwright test"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "@shared/types": "workspace:*",
    "@shared/client": "workspace:*",
    "@shared/ui": "workspace:*",
    "@radix-ui/react-dialog": "^1.0.0",
    "@radix-ui/react-dropdown-menu": "^2.0.0",
    "react-hook-form": "^7.0.0",
    "zod": "^3.0.0",
    "zustand": "^4.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "typescript": "^5.0.0",
    "tailwindcss": "^3.0.0",
    "vitest": "^1.0.0",
    "playwright": "^1.0.0"
  }
}
```

#### 3. Configure Next.js

```javascript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
  },
  env: {
    SHARED_SERVICES_URL: process.env.SHARED_SERVICES_URL,
    ORG_ID: process.env.ORG_ID,
  },
}

module.exports = nextConfig
```

#### 4. Set up Shared Services Integration

```typescript
// src/lib/shared-services.ts
import { SharedServicesClient } from '@shared/client';

export const sharedServices = new SharedServicesClient({
  baseUrl: process.env.NEXT_PUBLIC_SHARED_SERVICES_URL!,
  orgId: process.env.NEXT_PUBLIC_ORG_ID!,
});
```

## 🏗️ Application Architecture

### Directory Structure

```
apps/your-app/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── layout.tsx         # Root layout with auth provider
│   │   ├── page.tsx           # Home page
│   │   ├── (auth)/            # Authentication group
│   │   │   ├── login/
│   │   │   └── register/
│   │   ├── your-feature/      # Main feature pages
│   │   │   ├── page.tsx
│   │   │   ├── [id]/
│   │   │   └── new/
│   │   └── api/               # API routes
│   │       └── your-feature/
│   ├── components/            # React components
│   │   ├── ui/               # Reusable UI components
│   │   ├── forms/            # Form components
│   │   └── layout/           # Layout components
│   ├── lib/                  # Utilities and configurations
│   │   ├── api/              # API client functions
│   │   ├── utils/            # Helper functions
│   │   ├── validations/      # Zod schemas
│   │   └── auth.ts           # Authentication helpers
│   └── types/                # App-specific types
├── public/                   # Static assets
├── prisma/                   # App-specific database (optional)
├── tests/                    # Test files
├── Dockerfile               # Container configuration
└── README.md                # App documentation
```

### Core Patterns

#### 1. Authentication Integration

```typescript
// src/lib/auth.ts
import { SharedServicesClient } from '@shared/client';
import type { AuthContext } from '@shared/types';

export async function getAuthContext(request: Request): Promise<AuthContext | null> {
  const token = request.headers.get('authorization')?.replace('Bearer ', '');
  
  if (!token) {
    return null;
  }

  try {
    const sharedServices = new SharedServicesClient({
      baseUrl: process.env.SHARED_SERVICES_URL!,
      orgId: process.env.ORG_ID!,
    });

    return await sharedServices.verifyToken(token);
  } catch (error) {
    return null;
  }
}
```

#### 2. API Route Pattern

```typescript
// src/app/api/skills/route.ts
import { getAuthContext } from '@/lib/auth';
import { sharedServices } from '@/lib/shared-services';

export async function GET(request: Request): Promise<Response> {
  try {
    // 1. Authenticate
    const authContext = await getAuthContext(request);
    if (!authContext) {
      return new Response(
        JSON.stringify({ status: 'error', message: 'Unauthorized' }),
        { status: 401 }
      );
    }

    // 2. Check permissions
    const hasPermission = authContext.permissions.includes('skills:read');
    if (!hasPermission) {
      return new Response(
        JSON.stringify({ status: 'error', message: 'Forbidden' }),
        { status: 403 }
      );
    }

    // 3. Business logic
    const skills = await getSkills();

    // 4. Log activity
    await sharedServices.logActivity({
      appName: 'skills-assessment',
      action: 'skills.list',
      resourceType: 'skill',
      metadata: { count: skills.length }
    });

    return Response.json({
      data: skills,
      status: 'success'
    });
  } catch (error) {
    console.error('API Error:', error);
    return new Response(
      JSON.stringify({ status: 'error', message: 'Internal server error' }),
      { status: 500 }
    );
  }
}
```

#### 3. Client-Side State Management

```typescript
// src/lib/store.ts
import { create } from 'zustand';
import type { User } from '@shared/types';

interface AppState {
  user: User | null;
  isLoading: boolean;
  setUser: (user: User | null) => void;
  setLoading: (loading: boolean) => void;
}

export const useAppStore = create<AppState>((set) => ({
  user: null,
  isLoading: true,
  setUser: (user) => set({ user }),
  setLoading: (isLoading) => set({ isLoading }),
}));
```

## 📊 Database Integration

### Option 1: Shared Database Tables

For simple applications, use the shared database with app-specific tables:

```sql
-- App-specific tables in shared database
CREATE TABLE skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID REFERENCES organizations(id),
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  skill_id UUID REFERENCES skills(id),
  level INTEGER CHECK (level >= 1 AND level <= 5),
  assessed_at TIMESTAMP DEFAULT NOW()
);
```

### Option 2: Separate Application Database

For complex applications, use a separate database:

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Skill {
  id          String   @id @default(uuid())
  orgId       String   @map("org_id")
  name        String
  category    String?
  description String?
  createdAt   DateTime @default(now()) @map("created_at")
  
  userSkills UserSkill[]
  
  @@map("skills")
}

model UserSkill {
  id         String   @id @default(uuid())
  userId     String   @map("user_id")
  skillId    String   @map("skill_id")
  level      Int
  assessedAt DateTime @default(now()) @map("assessed_at")
  
  skill Skill @relation(fields: [skillId], references: [id])
  
  @@map("user_skills")
}
```

## 🧪 Testing Strategy

### 1. Unit Tests

```typescript
// tests/components/SkillCard.test.tsx
import { render, screen } from '@testing-library/react';
import { SkillCard } from '@/components/SkillCard';

describe('SkillCard', () => {
  const mockSkill = {
    id: '1',
    name: 'TypeScript',
    category: 'Programming',
    level: 4
  };

  it('renders skill information', () => {
    render(<SkillCard skill={mockSkill} />);
    
    expect(screen.getByText('TypeScript')).toBeInTheDocument();
    expect(screen.getByText('Programming')).toBeInTheDocument();
  });
});
```

### 2. API Route Tests

```typescript
// tests/api/skills.test.ts
import { GET } from '@/app/api/skills/route';
import { mockAuthContext } from '@/tests/mocks';

describe('/api/skills', () => {
  it('returns skills for authenticated user', async () => {
    const request = new Request('http://localhost/api/skills', {
      headers: { authorization: 'Bearer valid-token' }
    });

    const response = await GET(request);
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data.status).toBe('success');
    expect(Array.isArray(data.data)).toBe(true);
  });
});
```

### 3. E2E Tests

```typescript
// tests/e2e/skills-flow.spec.ts
import { test, expect } from '@playwright/test';

test('user can assess skills', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'user@example.com');
  await page.fill('[data-testid="password"]', 'password');
  await page.click('[data-testid="login-button"]');

  await page.goto('/skills');
  await page.click('[data-testid="assess-skill-button"]');
  
  await expect(page.locator('[data-testid="skill-assessment"]')).toBeVisible();
});
```

## 🚀 Deployment

### Development

```bash
# Start the application
npm run dev

# Access at http://localhost:3003
```

### Production Build

```dockerfile
# Dockerfile
FROM node:18-alpine AS base

# Install dependencies
FROM base AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Build application
FROM base AS builder
WORKDIR /app
COPY . .
RUN npm ci
RUN npm run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000

CMD ["node", "server.js"]
```

## 📝 Best Practices

### 1. Code Organization

- Keep components small and focused
- Use consistent naming conventions
- Organize by feature, not by file type
- Export components from index files

### 2. Error Handling

```typescript
// Consistent error boundary
export function ErrorBoundary({ children }: { children: React.ReactNode }) {
  return (
    <ErrorBoundary
      fallback={<ErrorFallback />}
      onError={(error, errorInfo) => {
        console.error('Application error:', error, errorInfo);
        // Log to monitoring service
      }}
    >
      {children}
    </ErrorBoundary>
  );
}
```

### 3. Performance

- Use React.memo for expensive components
- Implement proper loading states
- Optimize images with Next.js Image component
- Use dynamic imports for code splitting

### 4. Security

- Always validate user permissions
- Sanitize user inputs
- Use HTTPS in production
- Implement proper CORS policies

## 🔄 Integration Checklist

When creating a new app, ensure:

- [ ] Shared services client configured
- [ ] Authentication integration working
- [ ] Database tables created (if needed)
- [ ] API routes follow standard patterns
- [ ] Error handling implemented
- [ ] Tests written
- [ ] Documentation updated
- [ ] Docker configuration added
- [ ] CI/CD pipeline configured

## 📚 Next Steps

1. **Review the generated code** to understand patterns
2. **Customize the application** for your specific use case
3. **Add your business logic** following established patterns
4. **Write comprehensive tests** for your features
5. **Update documentation** with app-specific information

## 🆘 Troubleshooting

**Common Issues:**

- **Port conflicts**: Change the port in package.json dev script
- **Shared services connection**: Verify SHARED_SERVICES_URL environment variable
- **Authentication issues**: Check token validation in shared services
- **Build failures**: Ensure all dependencies are properly installed

**Getting Help:**

- Check the [troubleshooting guide](./troubleshooting.md)
- Review similar applications in the `apps/` directory
- Ask in the team chat or create an issue

---

**Happy building! 🚀**