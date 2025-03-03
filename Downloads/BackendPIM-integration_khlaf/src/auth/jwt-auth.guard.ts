import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class JwtAuthGuard implements CanActivate {
    constructor(private jwtService: JwtService) {}

    canActivate(context: ExecutionContext): boolean | Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const token = this.extractTokenFromHeader(request);

        if (!token) {
            throw new UnauthorizedException('Authorization token is missing');
        }

        try {
            const payload = this.jwtService.verify(token);
            // Injecter req.user avec le payload original
            request.user = payload;

            // Générer un nouveau token si nécessaire (optionnel, selon vos besoins)
            const newToken = this.jwtService.sign(
                { userId: payload.userId, fullName: payload.fullName, email: payload.email, gender: payload.gender, birthday: payload.birthday },
                { expiresIn: '5m' }
            );
            request.newToken = newToken;
        } catch {
            throw new UnauthorizedException('Invalid or expired token');
        }

        return true;
    }

    private extractTokenFromHeader(request: any): string | null {
        const authHeader = request.headers['authorization'];
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return null;
        }
        return authHeader.split(' ')[1];
    }
}
