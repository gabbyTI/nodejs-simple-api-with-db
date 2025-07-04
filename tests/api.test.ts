import request from 'supertest';
import { app } from '../src/server';

describe('API Integration Tests', () => {
  describe('Health Endpoint', () => {
    it('should return healthy status', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
      expect(response.body.status).toBe('healthy');
      expect(response.body.timestamp).toBeDefined();
    });
  });

  describe('Users Endpoints', () => {
    const testUser = { name: 'Test User', email: 'test@example.com' };

    it('should create a new user', async () => {
      const response = await request(app)
        .post('/users')
        .send(testUser);
      
      expect(response.status).toBe(201);
      expect(response.body.name).toBe(testUser.name);
      expect(response.body.email).toBe(testUser.email);
      expect(response.body.id).toBeDefined();
    });

    it('should get all users', async () => {
      const response = await request(app).get('/users');
      expect(response.status).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
    });
  });

  describe('Messages Endpoints', () => {
    const testMessage = { content: 'Test message content' };

    it('should create a new message', async () => {
      const response = await request(app)
        .post('/messages')
        .send(testMessage);
      
      expect(response.status).toBe(201);
      expect(response.body.content).toBe(testMessage.content);
      expect(response.body.id).toBeDefined();
      expect(response.body.timestamp).toBeDefined();
    });

    it('should get all messages', async () => {
      const response = await request(app).get('/messages');
      expect(response.status).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
    });
  });
});
