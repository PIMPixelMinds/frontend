import { Test, TestingModule } from '@nestjs/testing';
import { HistoriqueController } from './historique.controller';
import { HistoriqueService } from './historique.service';

describe('HistoriqueController', () => {
  let controller: HistoriqueController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HistoriqueController],
      providers: [HistoriqueService],
    }).compile();

    controller = module.get<HistoriqueController>(HistoriqueController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
